import React, {useCallback, useEffect, useState} from "react";
import axios from "axios";
import {Alert, Button, Col, Container, Form, Modal, ModalBody, Row, Spinner} from "react-bootstrap";
import {Tile} from "./Tile";
import {CreateTile} from "./CreateTile";
import {ItemTile} from "./ItemTile";

const API_BASE = `http://${window.location.hostname}:8080`;
export const ItemPage = () => {
    const [college, setCollege] = useState(null);
    const [shop, setShop] = useState(null);
    const [category, setCategory] = useState(null);
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [form, setForm] = useState({item_name: "", image_path: "", price: "", stock_quantity: ""});
    const [showCreate, setShowCreate] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    
    const loadItems = useCallback(async () => {
        setError("");
        setLoading(true);
        try{
            if(!category?.id){
                setError("No categories found in session. Please login again.");
                return;
            }
            const res = await axios.get(
                `${API_BASE}/itemList/fetchItems`,{
                    params: {categoryId: category.id},
                    validateStatus: () => true,
                });
            if(res.status === 302 && Array.isArray(res.data)){
                setItems(res.data);
            } else if (res.status === 204){
                setItems([]);
            } else if(res.status === 500){
                setError("Oops.. Something went wrong. Internal Server Error");
            } else{
                setError(res.data || "Failed to fetch items.");
            }
        } catch{
            setError("Unexpected error happened! Error Fetching Items. Please try again later.");
        } finally {
            setLoading(false);
        }
    }, [category?.id]);

    useEffect(() => {
        try{
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            const savedShop = JSON.parse(localStorage.getItem("shop"));
            const savedCategory = JSON.parse(localStorage.getItem("category"));
            setCollege(savedCollege);
            setShop(savedShop);
            setCategory(savedCategory)
        } catch{
            setCollege(null);
            setShop(null);
            setCategory(null);
        }
        loadItems();
    }, [loadItems]);
    
    const openCreate = () => {
        setForm({
            item_name: "",
            image_path: "",
            price: "",
            stock_quantity: ""
        });
        setShowCreate(true);
    }
    
    const closeCreate = () => setShowCreate(false);
    
    const onFormChange = (e) => {
        const { name, value } = e.target;
        setForm((f) => ({...f, [name]: value}));
    };
    
    const submitCreate = async (e) => {
        e.preventDefault();
        if(!category?.id){
            setError("No category found in session. Please sign in again.");
            return;
        }
        setSubmitting(true);
        
        try{
            const payload = {
                category_id: category.id,
                item_name: form.item_name,
                image_path: form.image_path,
                price: form.price,
                stock_quantity: form.stock_quantity
            };
            
            const res = await axios.post(
                `${API_BASE}/itemList/createItem`,
                payload, {
                    validateStatus: () => true
                }
            );
            
            if(res.status === 201 || res.status === 200){
                closeCreate();
                await loadItems();
            } else{
                const msg = res.data || "Failed to create item.";
                Error(msg);
            }
        } catch (err){
            Error(err.response?.data || "Something went wrong. Please try again later.");
        } finally {
            setSubmitting(false);
        }
    }
    
    return(
        <Container fluid className="bg-white">
            <Row className="mb-3">
                <Col className="p-0">
                    <p className="text-center text-white bg-primary m-0 w-100 fs-6 text-uppercase d-flex align-items-center justify-content-center"
                        style={{borderRadius: 0, height: "50px"}}>
                        {category?.name ? `${category.name} - Items` : "Items"}
                    </p>
                </Col>
            </Row>

            {loading && (
                <Row>
                    <Col className="d-flex align-items-center">
                        <Spinner animation="border" role="status" className="me-2"/>
                        <span>Loading items...</span>
                    </Col>
                </Row>
            )}

            {!loading && error && (
                <Row>
                    <Col>
                        <Alert variant="danger">{error}</Alert>
                    </Col>
                </Row>
            )}

            {!loading && !error && items.length === 0 && (
                <Row>
                    <Col>
                        <Alert variant="info">No items found for this category.</Alert>
                    </Col>
                </Row>
            )}

            {!loading && !error && (
                <Row className="g-3 align-items-start">
                    {items.map((item) => (
                        <Col key={item.item_id} xs="12" sm="6" md="4" lg="3" xl="3">
                            {/*<Tile id={item.item_id} name={item.item_name} image_path={item.image_path} price={item.price} stock_quantity={item.stock_quantity} type="item" onUpdate={loadItems}/>*/}
                            <ItemTile id={item.item_id} name={item.item_name} image_path={item.image_path} price={item.price} stock_quantity={item.stock_quantity} type="item" onUpdate={loadItems}/>
                        </Col>
                    ))}
                    <Col xs="12" sm="6" md="4" lg="3" xl="3">
                        <CreateTile openCreate={openCreate} type="item"/>
                    </Col>
                </Row>
            )}

            <Modal show={showCreate} onHide={closeCreate} centered>
                <Form onSubmit={submitCreate}>
                    <Modal.Header closeButton>
                        <Modal.Title>Create Item</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3" controlId="itemName">
                            <Form.Label>Item Name</Form.Label>
                            <Form.Control
                                name="item_name"
                                type="text"
                                placeholder="Enter item name"
                                value={form.item_name}
                                onChange={onFormChange}
                                required
                                maxLength={128}/>
                        </Form.Group>
                        <Form.Group className="mb-3" controlId="imagePath">
                            <Form.Label>Image Path</Form.Label>
                            <Form.Control
                                name="image_path"
                                type="text"
                                placeholder="Enter image path"
                                value={form.image_path}
                                onChange={onFormChange}
                                required
                                maxLength={128}/>
                        </Form.Group>
                        <Form.Group className="mb-3" controlId="price">
                            <Form.Label>Price</Form.Label>
                            <Form.Control
                                name="price"
                                type="text"
                                placeholder="Enter price"
                                value={form.price}
                                onChange={onFormChange}
                                required
                                maxLength={128}/>
                        </Form.Group>
                        <Form.Group className="mb-3" controlId="stockQuantity">
                            <Form.Label>Stock Quantity</Form.Label>
                            <Form.Control
                                name="stock_quantity"
                                type="text"
                                placeholder="Enter stock quantity"
                                value={form.stock_quantity}
                                onChange={onFormChange}
                                required
                                maxLength={128}/>
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={closeCreate} disabled={submitting}>Cancel</Button>
                        <Button variant="primary" type="submit" disabled={submitting}>{submitting ? "Creating..." : "Create"}</Button>
                    </Modal.Footer>
                </Form>
            </Modal>
        </Container>
    );
}
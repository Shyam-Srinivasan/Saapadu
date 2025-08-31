import {Alert, Button, Col, Container, Form, Modal, Row, Spinner} from "react-bootstrap";
import React, {useCallback, useEffect, useState} from "react";
import axios from "axios";
import {Tile} from "./Tile";
import {CreateTile} from "./CreateTile";

const API_BASE = `http://${window.location.hostname}:8080`;

export const CategoryPage = () => {
    const [college, setCollege] = useState(null);
    const [categories, setCategories] = useState([]);
    const [shop, setShop] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [form, setForm] = useState({category_name: "", image_path: ""});
    const [showCreate, setShowCreate] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    
    const loadCategories = useCallback( async () => {
        setError("");
        setLoading(true);
        try{
            if(!shop?.id){
                setError("No shops found in session. Please Sign in again.");
                return;
            }
            const res = await axios.get(
                `${API_BASE}/categoryList/fetchCategories`,{
                    params: {shopId: shop.id},
                    validateStatus: () => true
                });
            if(res.status === 200 && Array.isArray(res.data)){
                setCategories(res.data);
            } else if(res.status === 204){
                setCategories([]);
            } else if(res.data === 404){
                setError("Organization not found.");
            } else{
                setError(res.data || "Failed to fetch categories.");
            }
        } catch{
            setError("Error fetching categories. Please try again later.");
        } finally {
            setLoading(false);
        }
    }, [shop?.id]);
    
    useEffect(() => {
        try {
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            const savedShop = JSON.parse(localStorage.getItem("shop"));
            setCollege(savedCollege);
            setShop(savedShop);
        } catch {
            setCollege(null);
            setShop(null);
        }
        loadCategories();
    }, [loadCategories]);
    
    const openCreate = () => {
        setForm({
            category_name: "",
            image_path: ""
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
        if(!shop?.id){
            setError("No shop found in session. Please sign in again.")
            return;
        }

        setSubmitting(true);

        try{
            const payload = {
                shop_id: shop.id,
                category_name: form.category_name,
                image_path: form.image_path
            };

            const res = await axios.post(
                `${API_BASE}/categoryList/createCategory`,
                payload,
                {
                    validateStatus: () => true
                }
            );
            if(res.status === 201 || res.status === 200){
                closeCreate();
                await loadCategories();
            } else{
                const msg = res.data || "Failed to create category.";
                Error(msg);
            }
        } catch (err) {
            Error(err.response?.data || "Network error while creating category");
        } finally {
            setSubmitting(false);
        }
    }
    
    return(
        <Container fluid className="bg-white min-vh-100">
            <Row className="mb-3">
                <Col className="p-0">
                    <p className="text-center text-white bg-primary m-0 w-100 fs-6 text-uppercase d-flex align-items-center justify-content-center"
                        style={{borderRadius: 0, height: "50px"}}>
                        {shop?.name ? `${shop.name} - Shop` : "Shops"}
                    </p>
                </Col>
            </Row>

            {loading && (
                <Row>
                    <Col className="d-flex align-items-center">
                        <Spinner animation="border" role="status" className="me-2"/>
                        <span>Loading categories...</span>
                                 
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

            {!loading && !error && categories.length === 0 && (
                <Row>
                    <Col>
                        <Alert variant="info">No categories found for this shop.</Alert>
                    </Col>
                </Row>
            )}

            {!loading && !error && (
                <Row className="g-1 justify-content-start">
                    {categories.map((category) => (
                        <Col key={category.category_id ?? category.categoryId} xs="12" sm="6" md="4" lg="3" xl="3">
                            <Tile name={category.category_name ?? category.categoryName} id={category.category_id ?? category.categoryId} image_path={category.image_path} onUpdate={loadCategories} type="category"/>
                        </Col>
                    ))}
                    <Col xs="12" sm="6" md="4" lg="3" xl="3">
                        <CreateTile openCreate={openCreate} type="category"/>
                    </Col>
                </Row>
            )}
            <Modal show={showCreate} onHide={closeCreate} centered>
                <Form onSubmit={submitCreate}>
                    <Modal.Header closeButton>
                        <Modal.Title>Create Category</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3" controlId="categoryName">
                            <Form.Label>Category Name</Form.Label>
                            <Form.Control
                                name="category_name"
                                type="text"
                                placeholder="Enter category name"
                                value={form.category_name}
                                onChange={onFormChange}
                                required
                                maxLength={128}
                            />
                        </Form.Group>
                        <Form.Group className="mb-2" controlId="imagePath">
                            <Form.Label>Image Path</Form.Label>
                            <Form.Control
                                name="image_path"
                                type="text"
                                placeholder="Enter image path"
                                value={form.image_path}
                                onChange={onFormChange}
                                required
                                maxLength={16}
                            />
                            <Form.Text muted>Max 16 characters.</Form.Text>
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={closeCreate} disabled={submitting}>
                            Cancel
                        </Button>
                        <Button variant="primary" type="submit" disabled={submitting}>
                            {submitting ? "Creating..." : "Create"}
                        </Button>
                    </Modal.Footer>
                </Form>
            </Modal>
            
        </Container>
    );
}